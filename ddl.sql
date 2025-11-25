-- Active: 1764109112421@@127.0.0.1@5432@prova_db

create database prova_db;

CREATE Table especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) not null unique,
    descricao TEXT
);

CREATE Table cargos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) not null unique,
    salario_base DECIMAL(10,2) NOT NULL check (salario_base > 0),
    carga_horaria INT NOT NULL check (carga_horaria > 0)
);

CREATE Table planos_saude (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) not null unique,
    cnpj VARCHAR(18) not null unique,
    telefone VARCHAR(20) NOT NULL,
    cobertura_percentual DECIMAL(5,2) check (cobertura_percentual BETWEEN 0 AND 100)
);

CREATE TABLE tipos_exames (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    valor DECIMAL(10,2) NOT NULL check (valor > 0),
    preparo TEXT
);

CREATE TABLE medicamentos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    principio_ativo VARCHAR(100) NOT NULL,
    fabricante VARCHAR(100) NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL check (valor_unitario > 0),
    estoque INT NOT NULL DEFAULT 0
);

CREATE TABLE funcionario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    sexo VARCHAR(1) check (sexo IN ('M', 'F')),
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE,
    endereco VARCHAR(200) NOT NULL,
    cargo_id INT NOT NULL,
    data_admissao date NOT NULL,
    salario DECIMAL(10,2) NOT NULL check (salario > 0),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    constraint fk_cargo_funcionario
        foreign key (cargos_id)
        references cargos(id)
        on delete RESTRICT
        on update CASCADE
);

CREATE Table medicos (
    id SERIAL PRIMARY KEY,
    funcionario_id INT NOT NULL UNIQUE,
    crm VARCHAR(20) NOT NULL UNIQUE,
    especialidades_id INT NOT NULL,

    constraint fk_medico_funcionario
        Foreign Key (funcionario_id)
        references funcionario(id)
        on delete RESTRICT
        on update CASCADE,

    constraint fk_especialidade_medico
        foreign key (especialidades_id)
        references especialidades(id)
        on delete RESTRICT
        on update CASCADE
);

CREATE Table enfermeiros (
    id SERIAL PRIMARY KEY,
    funcionario_id INT NOT NULL UNIQUE,
    coren VARCHAR(20) NOT NULL UNIQUE,

    constraint fk_funcionarios_enfermeiro
        foreign key (funcionario_id)
        references funcionario(id)
        on delete RESTRICT
        on update CASCADE
);

CREATE Table setores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) not null unique,
    andar int4 NOT NULL,
    ramal VARCHAR(10)
);

CREATE Table leitos (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(10) not null unique,
    setor_id INT NOT NULL,
    tipo VARCHAR(20) check (tipo IN ('UTI', 'Enfermaria', 'Apartamento')),
    status VARCHAR(20) DEFAULT 'Disponível',

    constraint fk_setor_leito
        foreign key (setor_id)
        references setores(id)
        on delete RESTRICT
        on update CASCADE
);

CREATE Table salas_cirurgia (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(10) not null unique,
    andar int NOT NULL,
    status VARCHAR(20) DEFAULT 'Disponível'
);

CREATE Table pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    sexo VARCHAR(1) check (sexo IN ('M', 'F')),
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    endereco VARCHAR(200) NOT NULL,
    plano_saude_id INT,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    constraint fk_plano_saude_paciente
        foreign key (plano_saude_id)
        references planos_saude(id)
        on delete SET NULL
        on update CASCADE
);

CREATE Table consultas (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL,
    medicos_id INT NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    motivo TEXT,
    diagnostico TEXT,
    observacao TEXT,
    valor DECIMAL(10,2) NOT NULL check (valor > 0),

    constraint fk_paciente_consulta
        foreign key (paciente_id)
        references pacientes(id)
        on delete RESTRICT
        on update CASCADE,

    constraint fk_medico_consulta
        foreign key (medicos_id)
        references medicos(id)
        on delete RESTRICT
        on update CASCADE
);

CREATE TABLE exames (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL,
    tipo_exame_id INT NOT NULL,
    data_solicitacao date NOT NULL,
    data_realizacao date,
    status VARCHAR(20) DEFAULT 'Pendente',
    resultado TEXT,

    constraint fk_paciente_exame
        foreign key (paciente_id)
        references pacientes(id)
        on delete RESTRICT
        on update CASCADE,

    constraint fk_tipo_exame
        foreign key (tipo_exame_id)
        references tipos_exames(id)
        on delete RESTRICT
        on update CASCADE
);

CREATE TABLE prescricoes (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL,
    data_prescricao date NOT NULL,
    observacao TEXT,

    constraint fk_consulta_prescricoes
        foreign key (consulta_id)
        references consultas(id)
        on delete restrict
        on update cascade
);

create table itens_prescricao (
    id serial primary key,
    prescricao_id int not null,
    medicamento_id int not null,
    dosagem varchar(50) not null,
    frequencia varchar(50) not null,
    duracao varchar(50) not null,
    quantidade int not null check ( quantidade > 0 ),

    constraint fk_prescricao_itens
        foreign key (prescricao_id)
        references prescricoes(id)
        on delete restrict
        on update cascade
);

create table internacoes (
    id serial primary key,
    paciente_id int not null,
    leito_id int not null,
    medico_id int not null,
    data_entrada timestamp not null,
    data_alta timestamp,
    motivo text not null,
    diagnostico text,
    observacoes text,

    constraint fk_paciente_internacoes
        foreign key (paciente_id)
        references pacientes(id)
        on delete restrict
        on update cascade
);

create table cirurgia (
    id serial primary key,
    paciente_id int not null,
    sala_cirurgia_id int not null,
    medico_responsavel_id int not null,
    data_hora timestamp not null,
    tipo_cirurgia varchar(100) not null,
    duracao_minutos int check ( duracao_minutos > 0 ),
    status varchar(20) default 'Agendada',
    observacoes text,

    constraint fk_paciente_cirurgia
        foreign key (paciente_id)
        references pacientes(id)
        on delete restrict
        on update cascade
);

create table equipe_cirurgia (
    id serial primary key,
    cirurgia_id int not null,
    medico_id int not null,
    funcao varchar(50) not null,

    constraint fk_cirurgia_equipe
        foreign key (cirurgia_id)
        references cirurgia(id)
        on delete restrict
        on update cascade,

    constraint fk_medico_equipe
        foreign key (medico_id)
        references medicos(id)
        on delete restrict
        on update cascade
);

create table faturas (
    id serial primary key,
    paciente_id int not null,
    plano_saude_id int not null,
    data_emissao date not null,
    valor_total decimal(10,2) not null check ( valor_total > 0 ),
    valor_plano decimal(10,2) default 0,
    valor_paciente decimal(10,2) not null,
    status varchar(20) default 'Pendente',
    data_pagamento date,

    constraint fk_paciente_fatura
        foreign key (paciente_id)
        references pacientes(id)
        on delete restrict
        on update cascade,

    constraint fk_plano_fatura
        foreign key (plano_saude_id)
        references planos_saude(id)
        on delete restrict
        on update cascade
);
