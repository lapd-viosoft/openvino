#!/bin/bash
yum install -y sudo vim net-tools epel-release
rpm -v --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
yum install ffmpeg ffmpeg-devel wget unzip -y



cd  /root/openvino
mkdir -p openvino
cd openvino
wget https://storage.googleapis.com/coverr-main/zip/Rainy_Street.zip
unzip Rainy_Street.zip

cd /root/openvino
cat > downstream.sdp << EOL
v=0
o=- 0 0 IN IP4 127.0.0.1
s=No Name
c=IN IP4 127.0.0.1
t=0 0
a=tool:libavformat 56.40.101
m=video 5001 RTP/AVP 26
EOL

cat > start.sh << 'EOL'
#!/bin/bash
trap "exit" SIGINT SIGTERM
set -m
./tx_video.sh &
sleep 2
taskset -c 1 ffplay -reorder_queue_size 0  -i downstream.sdp
fg
EOL
chmod a+x start.sh

cat > tx_video.sh << 'EOL'
#!/bin/bash
trap "exit" SIGINT SIGTERM
while :
do
  taskset -c 2 ffmpeg -re -i Rainy_Street.mp4 -pix_fmt yuvj420p \
    -vcodec mjpeg -map 0:0 -pkt_size 1200 -f rtp rtp://openvino.openness:5000 > \
    /dev/null 2>&1 < /dev/null
done
EOL
chmod a+x tx_video.sh
