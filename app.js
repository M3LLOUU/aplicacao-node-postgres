const { Client } = require('pg');

const client = new Client({
    user: 'postgres',
    password: 'Jaime2024',
    host: 'localhost',
    port: 5432,
    database: 'aula_node_postgres'
});

async function buscarClientes(){
    try {
        await client.connect();

        const resultado = await client.query('SELECT * FROM cliente');

        console.log("Clientes encontrados: ");
        console.log(resultado.rows);
    
        await client.end();
    } catch (err) {
        console.error("Erro:", err);
    }   
}

async function inserirCliente(nome, email){
    try {
        await client.connect();

        const query = `
        INSERT INTO cliente (nome, email)
        VALUES('$1, $2');
        RETURNING *
        `;

        const resultado = await client.query(query, [nome, email]);

        console.log("Clientes cadastrados");
        console.log(resultado.rows[0]);

        await client.end();


    } catch (err) {
        console.error("Erro:", err)
    }
}

inserirCliente('teste', 'teste@teste.com');

buscarClientes();