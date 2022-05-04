package main

import (
	"encoding/json"
	"net/http"
	"os"

	"cloud.google.com/go/storage"
	"github.com/gin-gonic/gin"
)

type MessageContent struct {
	MessageId  string `json:"messageId"`
	ShouldFail bool   `json:"shouldFail"`
}

type PubSubMessage struct {
	Message struct {
		Data []byte `json:"data,omitempty"`
		ID   string `json:"messageId"`
	} `json:"message"`
}

func main() {
	r := gin.Default()

	r.POST("/", processMessage)

	r.Run()
}

func processMessage(c *gin.Context) {
	var m PubSubMessage
	var content MessageContent

	if err := c.ShouldBindJSON(&m); err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	if err := json.Unmarshal(m.Message.Data, &content); err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	if os.Getenv("SUBSCRIPTION_NAME") == "ordinary" {
		if content.ShouldFail {
			c.JSON(http.StatusNotAcceptable, "Should fail")
			return
		}
	}

	client, err := storage.NewClient(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	wc := client.Bucket(os.Getenv("BUCKET_NAME")).Object(m.Message.ID).NewWriter(c)

	defer wc.Close()

	if _, err := wc.Write(m.Message.Data); err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}
}
