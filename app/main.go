package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
)

var groupMap map[string][]string // Global

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
