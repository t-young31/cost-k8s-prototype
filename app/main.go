package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
)

var groupMap map[string][]string // Global

type TableRow struct {
	namespace    string
	costPerMonth float64 // £
}

type OpenCostNamespaceData struct {
	name                           string
	properties                     map[string]string
	window                         map[string]string
	start                          string
	end                            string
	minutes                        int
	cpuCores                       float64
	cpuCoreRequestAverage          float64
	cpuCoreUsageAverage            float64
	cpuCoreHours                   float64
	cpuCost                        float64
	cpuCostAdjustment              int
	cpuEfficiency                  float64
	gpuCount                       int
	gpuHours                       int
	gpuCost                        int
	gpuCostAdjustment              int
	networkTransferBytes           float64
	networkReceiveBytes            float64
	networkCost                    int
	networkCrossZoneCost           int
	networkCrossRegionCost         int
	networkInternetCost            int
	networkCostAdjustment          int
	loadBalancerCost               int
	loadBalancerCostAdjustment     int
	pvBytes                        float64
	pvByteHours                    float64
	pvCost                         int
	pvs                            map[string]string
	pvCostAdjustment               int
	ramBytes                       float64
	ramByteRequestAverage          float64
	ramByteUsageAverage            float64
	ramByteHours                   float64
	ramCost                        float64
	ramCostAdjustment              int
	ramEfficiency                  float64
	externalCost                   int
	sharedCost                     int
	totalCost                      float64
	totalEfficiency                float64
	proportionalAssetResourceCosts map[string]string
	lbAllocations                  string
	sharedCostBreakdown            map[string]string
}

type OpenCostData struct {
	code   int
	status string
	data   []OpenCostNamespaceData
}

func assertNotNil(e error) {
	if e != nil {
		panic(e)
	}
}

func removeDuplicates(strings []string) []string {
	tmp := make(map[string]bool)
	list := []string{}
	for _, item := range strings {
		if _, value := tmp[item]; !value {
			tmp[item] = true
			list = append(list, item)
		}
	}
	return list
}

func emailFromHeader(c *gin.Context) string {
	return c.Request.Header.Get("x-forwarded-email")
}

func env(key string) string {
	value := os.Getenv(key)
	if len(value) == 0 {
		panic(fmt.Sprintf("Environment variable [%v] not set", key))
	}
	return value
}

// Read a AAD group ID -> namespaces map defined in a json file
func groupMapFromFile(filepath string) map[string][]string {
	if !strings.HasSuffix(filepath, ".json") {
		panic("Group map must be a json file")
	}

	content, err := os.ReadFile(filepath)
	assertNotNil(err)

	var data map[string][]string
	err = json.Unmarshal(content, &data)
	assertNotNil(err)

	return data
}

// Get a list of unique namespaces visible to a user based on a comma separated list of groups
func userVisibleNamespaces(groups string) []string {
	var namespaces []string
	for _, groupId := range strings.Split(groups, ",") {
		groupNamespaces, ok := groupMap[groupId]
		if ok {
			namespaces = append(namespaces, groupNamespaces...)
		}
	}
	return removeDuplicates(namespaces)
}

func tableRows(namespaces []string) []TableRow {

	u, err := url.ParseRequestURI(env("OPENCOST_URL"))
	assertNotNil(err)
	u.Path = "/allocation"
	q := u.Query()
	q.Set("window", "1m")
	q.Set("aggregate", "namespace")
	u.RawQuery = q.Encode()

	var tableRows []TableRow

	//allocation   -d window=7d   -d aggregate=namespace   -d accumulate=false   -d resolution=1m

	resp, err := http.Get(u.String())
	if err != nil {
		return tableRows
	}
	fmt.Println(resp.Body)

	// data =
	return tableRows
}

func index(context *gin.Context) {
	groupsHeader := context.Request.Header.Get("x-forwarded-groups")
	namespaces := userVisibleNamespaces(groupsHeader)

	context.HTML(http.StatusOK, "index.tmpl.html", gin.H{
		"title":      "Hello " + emailFromHeader(context),
		"namespaces": namespaces,
	})
}

func main() {
	groupMap = groupMapFromFile(env("GROUP_MAP_PATH"))

	router := gin.Default()
	router.StaticFile("/favicon.ico", "./assets/favicon.ico")
	router.LoadHTMLGlob("templates/*")
	router.GET("/", index)

	router.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	router.Run()
}
