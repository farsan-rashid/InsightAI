CREATE ML_ENGINE ollama_engine
FROM ollama;

CREATE MODEL ollama_model
PREDICT answer
USING
    engine = 'ollama_engine',   -- engine name as created via CREATE ML_ENGINE
    model_name = 'llama3.2',             -- choose one of the models available from Ollama
    ollama_serve_url = 'http://host.docker.internal:11434',
    user_column = 'question',          -- column name that stores input from the user
    assistant_column = 'answer',       -- column name that stores output of the model (see PREDICT column) 
    verbose = True,
    prompt_template = 'Please generate SQL based on user question: {{question}}';

DESCRIBE MODEL ollama_model;

CREATE DATABASE demo_data   --you can define your own name here
WITH ENGINE = "postgres",
PARAMETERS = {
    "user": "demo_user",
    "password": "demo_password",
    "host": "samples.mindsdb.com",
    "port": "5432",
    "database": "demo",
    "schema": "demo_data"
};

CREATE SKILL text2sql_skill
USING
    type = 'text2sql',
    database = 'demo_data', -- a database name you created in the previous step
    tables = ['home_rentals'], -- optionally, list table(s) to be made accessible by an agent
    description = 'home_rentals contain home rentals data'; -- provide data description


CREATE AGENT agent
USING
    model = 'ollama_model',
    skills = ['text2sql_skill'];

SELECT question, answer
FROM agent
WHERE question = 'What is the average of sqft in demo_data.home_rentals table?';

