package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

func main() {

	client := &http.Client{}
	request, _ := http.NewRequest("GET", os.Getenv("OCOST_URL"), nil)
	request.Header.Add("x-forwarded-groups", os.Getenv("GROUP"))

	response, err := client.Do(request)
	if err != nil {
		panic(fmt.Sprintf("Failed to complete the request [%v]. Error: %v", request, err))
	}
	defer response.Body.Close()

	if response.StatusCode != 200 {
		panic(fmt.Sprintf("Failed to request [%v]. Status code: %v", request.URL, response.StatusCode))
	}

	body, err := io.ReadAll(response.Body)
	if err != nil {
		panic(fmt.Sprintf("Failed to read the body. Error: %v", err))
	}

	expectedNamespace := os.Getenv("EXPECTED_NAMESPACE")
	if expectedNamespace == "" {
		panic("EXPECTED_NAMESPACE must be set")
	}

	if !strings.Contains(string(body), expectedNamespace) {
		panic(fmt.Sprintf("Body did not include the expected [%v] namespace", expectedNamespace))
	}

	fmt.Printf("ocost returned an acceptable body:\n [%v]", string(body))
}
