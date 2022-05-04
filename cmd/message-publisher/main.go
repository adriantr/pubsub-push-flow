package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"sync"

	"cloud.google.com/go/pubsub"
	"github.com/gin-gonic/gin"
)

type MessageContent struct {
	ShouldFail bool `json:"shouldFail"`
}

func main() {
	r := gin.Default()

	r.POST("/generate-messages", generateMessages)

	r.Run()
}

func generateMessages(c *gin.Context) {
	var wg sync.WaitGroup

	projectId := os.Getenv("PROJECT_ID")
	topic := os.Getenv("TOPIC")

	client, err := pubsub.NewClient(c, projectId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	defer client.Close()

	t := client.Topic(topic)

	for i := 0; i < 10; i++ {
		messageContent := MessageContent{
			ShouldFail: getShouldFail(i),
		}

		//Skipping error handling here :-))
		msgJson, _ := json.Marshal(messageContent)

		result := t.Publish(c, &pubsub.Message{
			Data: msgJson,
		})

		wg.Add(1)

		go func(i int, res *pubsub.PublishResult) {
			defer wg.Done()

			_, err := res.Get(c)
			if err != nil {
				fmt.Fprintf(os.Stdout, "Failed to publish: %v", err)
				return
			}
		}(i, result)
	}

	wg.Wait()
}

func getShouldFail(i int) bool {
	if i == 0 {
		return true
	}

	return false
}
