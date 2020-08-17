python3 fetch_papers.py --max-index 100 --search-query cat:cs.CL
python3 download_pdfs.py
python3 parse_pdf_to_text.py
python3 thumb_pdf.py
python3 analyze.py
python3 buildsvm.py
python3 make_cache.py
serivce mongodb start
python3 serve.py --port 80