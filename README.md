# Пример работы с машинным обучением в Go

## Запуск

```
git clone https://github.com/a5i/try-go-ml-golangconf.git
cd try-go-ml-golangconf
mkdir -p data
chown -R 1000:1000 data
chown -R 1000:1000 project
docker-compose up --build
```

Или

```
git clone https://github.com/a5i/try-go-ml-golangconf.git
cd try-go-ml-golangconf
mkdir -p data
chown -R 1000:1000 data
chown -R 1000:1000 project
docker-compose -f docker-compose.hub.yml up
```

http://127.0.0.1

Пароль для входа в Jupyter Notebook - GolangConf

## Порядок запуска

- /examples - примеры работы с notebook + Go
- /project - примеры

- /project/opencv-human-pose-estimation.ipynb - оценка положения тела человека 
- /project/train-mnist.ipynb - обучение сети на данных MNIST (Python)
- /project/opencv-mnist.ipynb - использование сети из предыдущего пункта
- /project/golearn-knn.ipynb - GoLearn KNN
- /project/golearn-averageperceptron.ipynb - GoLearn 


## Что в комплекте

- OpenCV 4.1 https://opencv.org
- OpenVINO  https://software.intel.com/en-us/openvino-toolkit
- GoCV https://github.com/hybridgroup/gocv 
- GoLearn https://github.com/sjwhitworth/golearn
- GoNum https://github.com/gonum/gonum
- MxNet https://mxnet.apache.org (Python)

## Модели для OpenVINO + OpenCV

https://github.com/opencv/open_model_zoo
