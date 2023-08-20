.PHONY: backend

dcup:
	docker-compose up -d

dcdown:
	docker-compose down

back:
	docker exec -it backend /bin/bash -c "cd flask && python3 main.py"