FROM ubuntu
RUN apt-get upgrade && apt-get update && apt-get install -y python3 python3-pip

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt
RUN apt-get install -y imagemagick poppler-utils
COPY . .

RUN python3 fetch_papers.py --max-index 20 --search-query cat:cs.CL
RUN python3 download_pdfs.py
RUN python3 parse_pdf_to_text.py
# remove useage restrictions on convert
RUN mv /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xmlout

RUN python3 thumb_pdf.py
RUN python3 analyze.py
RUN apt-get install sqlite3
RUN sqlite3 as.db < schema.sql
RUN python3 buildsvm.py
RUN python3 make_cache.py

#install mongodb
RUN apt-get install -y wget 
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - 
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list 
RUN apt-get update 
RUN apt-get install -y mongodb-server
#RUN apt-get install -y mongodb-org

CMD service mongodb start && python3 serve.py --port 80