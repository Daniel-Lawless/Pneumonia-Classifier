# AWS’s official Lambda base image. For the AWS Lambda Python base image The current working directory (WORKDIR) is
# /var/task. This is where our code lives and Lambda looks for our handler.
FROM public.ecr.aws/lambda/python:3.12

# We should copy requirements before app.py because docker builds images in layers from top to bottom. If requirements
# does not change, docker reuses the cached layer and pip install is skipped. If only app.py is changed, only the final
# layer is rebuilt, leading to faster rebuilds.

# COPY <source on your machine> <destination inside the image>
# So this copies our requirements.txt file into the current working directory in the image giving us
# /var/task/requirements.txt. Could write COPY requirements.txt /var/task to be explicit, but it doesnt matter much.
COPY training/requirements.txt .

# Install Python dependencies into the Lambda task root. --no-cache-dir tells pip to not keep any installation cache.
# After this runs, our container has access to each package we listed in requirements.txt. These packages are installed
# at /var/task. This is where Python looks for imports at runtime.
RUN pip install --no-cache-dir -r requirements.txt

# Copy your application code into the current working directory giving us: /var/task/app.py
COPY app.py .

# app.py contains: handler = Mangum(app)
# We tell Lambda what handler to run using: "<filename>.<variable>"
CMD ["app.handler"]

# CMD in a normal docker container CMD ["python", "app.py"] means when the container starts, run python app.py
# (run the app.py file). So CMD means the default command to run when the container first starts.
# However, in a Lambda container when we write CMD ["app.handler"] we're not saying run handler when the container
# is ran, we are saying when Lambda receives an event, call handler from app.py.

# From this docker file, we can now create a docker image. We can run.
# docker build -t pneumonia-classifier-api .
# docker build tells docker to read a dockerfile and build an image from it.
# -t stands for tag. It assigns a name to the image we're building. In this case pneumonia-classifier-api.
# . at the end means use the current directory as the build context. To do this:
# 1: it will look in the current directory (build context) and search for a dockerfile called Dockerfile
# 2: Docker sets the build context. the . tells docker you may access files from this directory and its subdirectories.
# 3: Docker executes the docker file from top to bottom, and uses the files in the build context to complete it.