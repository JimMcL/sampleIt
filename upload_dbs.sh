#!sh

# Putty saved session name
PUTTY_SESS="Tenjin spiders"
set -x


# Start remote rsync daemon. See http://articles.manugarg.com/backup_rsync.html
plink -v -t "$PUTTY_SESS" rsync --daemon --port=1873 --config=\$HOME/rsyncd.conf

# ssh tunnel from local port 873 to remote port 1873
plink -v -N -L 873:localhost:1873 "$PUTTY_SESS" &

###

# Copy image and video files
rsync -av --chmod=a+rx -P public/ac 127.0.0.1::sampleIt/public
rsync -av --chmod=a+rx -P public/videos/videos 127.0.0.1::sampleIt/public/videos
rsync -av --chmod=a+rx -P public/images/thumbs 127.0.0.1::sampleIt/public/images
rsync -av --chmod=a+rx -P public/images/photos 127.0.0.1::sampleIt/public/images

# Copy mimetic variation CSV files
# No longer needed since equivalent files are in public/ac
#rsync -av --chmod=a+rx -P ../../Classes/Thesis/Morphometrics/*.csv 127.0.0.1::sampleIt/public

###
# Stop remote nginx
plink "$PUTTY_SESS" sudo service nginx stop

# Copy the sqlite database 
rsync -av -P db/production.sqlite3 127.0.0.1::sampleIt/db

# Start remote nginx
plink "$PUTTY_SESS" sudo service nginx start

# Kill tunnel
kill %1
