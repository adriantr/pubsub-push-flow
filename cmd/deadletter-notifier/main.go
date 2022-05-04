package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/mailgun/mailgun-go"
)

type MessageContent struct {
	MediaLink string `json:"mediaLink"`
	Name      string `json:"name"`
	Bucket    string `json:"bucket"`
}

type PubSubMessage struct {
	Message struct {
		Data []byte `json:"data,omitempty"`
		ID   string `json:"messageId"`
	} `json:"message"`
}

func main() {
	r := gin.Default()

	r.POST("/", processGsNotification)

	r.Run()
}

func processGsNotification(c *gin.Context) {
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

	domain := os.Getenv("MAILGUN_DOMAIN")

	mg := mailgun.NewMailgun(domain, os.Getenv("MAILGUN_API_KEY"))
	email := mg.NewMessage(
		fmt.Sprintf("Gs warning <mailgun@%s>", domain),
		"GS Notification",
		content.MediaLink,
		"adrian@strise.ai",
	)
	_, id, err := mg.Send(email)

	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		return
	}

	fmt.Printf("E-mail sent: %s", id)
}
