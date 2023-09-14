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
	Namespace    string
	CostPerMonth float64 // £
}

type Namespaces []string

func (namespaces Namespaces) Contains(query string) bool {
	for _, namespace := range namespaces {
		if namespace == query {
			return true
		}
	}
	return false
}

type OpenCostAPIResponse struct {
	Code   int                                `json:"code"`
	Status string                             `json:"status"`
	Data   []map[string]OpenCostNamespaceData `json:"data"`
}

type OpenCostNamespaceData struct {
	Name                       string            `json:"name"`
	Properties                 map[string]string `json:"properties"`
	Window                     map[string]string `json:"window"`
	Start                      string            `json:"start"`
	End                        string            `json:"end"`
	Minutes                    int               `json:"minutes"`
	CpuCores                   float64           `json:"cpuCores"`
	CpuCoreRequestAverage      float64           `json:"cpuCoreRequestAverage"`
	CpuCoreUsageAverage        float64           `json:"cpuCoreUsageAverage"`
	CpuCoreHours               float64           `json:"cpuCoreHours"`
	CpuCost                    float64           `json:"cpuCost"`
	CpuCostAdjustment          int               `json:"cpuCostAdjustment"`
	CpuEfficiency              float64           `json:"cpuEfficiency"`
	GpuCount                   int               `json:"gpuCount"`
	GpuHours                   int               `json:"gpuHours"`
	GpuCost                    int               `json:"gpuCost"`
	GpuCostAdjustment          int               `json:"gpuCostAdjustment"`
	NetworkTransferBytes       float64           `json:"networkTransferBytes"`
	NetworkReceiveBytes        float64           `json:"networkReceiveBytes"`
	NetworkCost                int               `json:"networkCost"`
	NetworkCrossZoneCost       int               `json:"networkCrossZoneCost"`
	NetworkCrossRegionCost     int               `json:"networkCrossRegionCost"`
	NetworkInternetCost        int               `json:"networkInternetCost"`
	NetworkCostAdjustment      int               `json:"networkCostAdjustment"`
	LoadBalancerCost           int               `json:"loadBalancerCost"`
	LoadBalancerCostAdjustment int               `json:"loadBalancerCostAdjustment"`
	PvBytes                    float64           `json:"pvBytes"`
	PvByteHours                float64           `json:"pvByteHours"`
	PvCost                     int               `json:"pvCost"`
	//Pvs string `json:"pvs"`
	PvCostAdjustment               int               `json:"pvCostAdjustment"`
	RamBytes                       float64           `json:"ramBytes"`
	RamByteRequestAverage          float64           `json:"ramByteRequestAverage"`
	RamByteUsageAverage            float64           `json:"ramByteUsageAverage"`
	RamByteHours                   float64           `json:"ramByteHours"`
	RamCost                        float64           `json:"ramCost"`
	RamCostAdjustment              int               `json:"ramCostAdjustment"`
	RamEfficiency                  float64           `json:"ramEfficiency"`
	ExternalCost                   int               `json:"externalCost"`
	SharedCost                     int               `json:"sharedCost"`
	TotalCost                      float64           `json:"totalCost"`
	TotalEfficiency                float64           `json:"totalEfficiency"`
	ProportionalAssetResourceCosts map[string]string `json:"proportionalAssetResourceCosts"`
	LbAllocations                  map[string]string `json:"lbAllocations"`
	SharedCostBreakdown            map[string]string `json:"sharedCostBreakdown"`
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

func env(key string) string {
	value := os.Getenv(key)
	if len(value) == 0 {
		panic(fmt.Sprintf("Environment variable [%v] not set", key))
	}
	return value
}

func getJson(fullUrl string, target interface{}) error {
	response, err := http.Get(fullUrl)
	if err != nil {
		return err
	}
	defer response.Body.Close()
	return json.NewDecoder(response.Body).Decode(target)
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
func userVisibleNamespaces(groups string) Namespaces {
	var namespaces Namespaces
	for _, groupId := range strings.Split(groups, ",") {
		groupNamespaces, ok := groupMap[groupId]
		if ok {
			namespaces = append(namespaces, groupNamespaces...)
		}
	}
	return removeDuplicates(namespaces)
}

func queryOpenCostData() []map[string]OpenCostNamespaceData {
	u, err := url.ParseRequestURI(env("OPENCOST_URL"))
	assertNotNil(err)
	u.Path = "/allocation"
	q := u.Query()
	q.Set("window", "31d")
	q.Set("aggregate", "namespace")
	u.RawQuery = q.Encode()

	var responseJson OpenCostAPIResponse
	if err := getJson(u.String(), &responseJson); err != nil {
		fmt.Printf("Failed to get JSON from %v. %#v\n", u.String(), err)
	}
	return responseJson.Data
}

func tableRows(visibleNamespaces Namespaces) []TableRow {
	var tableRows []TableRow

	for _, namespaceMap := range queryOpenCostData() {
		for _, namespaceData := range namespaceMap {
			if !visibleNamespaces.Contains(namespaceData.Name) {
				// fmt.Printf("%v was not visible\n", namespaceData.Name)
				continue
			}
			row := TableRow{
				Namespace:    namespaceData.Name,
				CostPerMonth: namespaceData.TotalCost,
			}
			tableRows = append(tableRows, row)
		}
	}
	return tableRows
}

func index(context *gin.Context) {
	groupsHeader := context.Request.Header.Get("x-forwarded-groups")
	namespaces := userVisibleNamespaces(groupsHeader)

	context.HTML(http.StatusOK, "index.tmpl.html", gin.H{
		"tableRows": tableRows((namespaces)),
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

	_ = router.Run()
}
