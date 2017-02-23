package data

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

type MnistImage []float32
type MnistLabel int // Onehot-encoded

type DataSet struct {
}

const (
	url         = "http://yann.lecun.com/exdb/mnist/"
	trainImages = "train-images-idx3-ubyte.gz"
	trainLabels = "train-labels-idx1-ubyte.gz"
	testImages  = "t10k-images-idx3-ubyte.gz"
	testLabels  = "t10k-labels-idx1-ubyte.gz"
	imageMagic  = 0x00000803
	labelMagic  = 0x00000801
	Width       = 28
	Height      = 28
)

func maybeDownload(dirname string, filename string) {
	filepath := fmt.Sprintf("%s/%s", dirname, filename)
	_, err := os.Stat(filepath)
	if err == nil {
		log.Println(filename, "is already downloaded")
		return
	}
	out, err := os.Create(filepath)
	if err != nil {
		log.Fatal("Fail to create:", err)
		return
	}

	log.Println("Downloading", filename)
	res, err := http.Get(url + filename)
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()
	n, err := io.Copy(out, res.Body)
	if err != nil || n == 0 {
		log.Fatal("Fail to write file:", err)
		return
	}
}

func NewDataSet(dirname string) *DataSet {
	files := []string{
		trainImages,
		trainLabels,
		testImages,
		testLabels,
	}

	for _, f := range files {
		maybeDownload(dirname, f)
	}


	return nil
}

func (ds DataSet) NextBatch() ([]MnistImage, []int) {
	return nil, nil
}
