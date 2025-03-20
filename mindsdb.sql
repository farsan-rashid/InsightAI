CREATE ML_ENGINE langchain_engine
FROM langchain;

CREATE MODEL langchain_ollama_model
PREDICT answer 
USING
     engine = 'langchain_engine',       -- engine name as created via CREATE ML_ENGINE
     provider = 'ollama',               -- one of the available providers
     model_name = 'llama3.2',             -- choose one of the models available from Ollama
     mode = 'conversational',           -- conversational mode
     user_column = 'question',          -- column name that stores input from the user
     assistant_column = 'answer',       -- column name that stores output of the model (see PREDICT column) 
     ollama_serve_url = 'http://host.docker.internal:11434',
     verbose = True,
     prompt_template = 'Answer the users input in a helpful way: {{question}}';

CREATE DATABASE datasource --you can define your own name here
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
    database = 'datasource', -- a database name you created in the previous step
    tables = ['house_sales'], -- optionally, list table(s) to be made accessible by an agent
    description = 'this is house sales data'; -- provide data description

CREATE AGENT ai_agent
USING
    model = 'langchain_ollama_model',
    skills = ['text2sql_skill'];

SHOW AGENTS;

SELECT question, answer
FROM ai_agent
WHERE question = 'how many houses were sold in 2015?';

--        
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

CREATE DATABASE demo_data--you can define your own name here
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
    database = 'datasource', -- a database name you created in the previous step
    tables = ['home_rentals'], -- optionally, list table(s) to be made accessible by an agent
    description = 'this is house rentals data'; -- provide data description


CREATE AGENT agent
USING
    model = 'ollama_model',
    skills = ['text2sql_skill'];

