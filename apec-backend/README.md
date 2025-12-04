# APEC Backend

Backend API para o aplicativo Flutter APEC

## Configuração

1. **Instale as dependências**:
   ```bash
   npm install
   ```

2. **Crie um arquivo `.env` na raiz do projeto**:
   ```
   MONGODB_URI=mongodb+srv://seu_usuario:sua_senha@seu_cluster.mongodb.net/apec_db?retryWrites=true&w=majority
   PORT=3000
   NODE_ENV=development
   ```

3. **Inicie o servidor**:
   ```bash
   npm start         # produção
   npm run dev       # desenvolvimento (com nodemon)
   ```

## Endpoints

### Eventos
- `GET /api/eventos` - Listar todos os eventos
- `GET /api/eventos/:id` - Obter um evento específico
- `POST /api/eventos` - Criar novo evento
- `PUT /api/eventos/:id` - Atualizar evento
- `DELETE /api/eventos/:id` - Deletar evento

## Estrutura de Pastas

```
apec-backend/
├── models/        # Schemas Mongoose
├── routes/        # Rotas da API
├── controllers/   # Controllers com lógica de negócio
├── server.js      # Arquivo principal
├── .env           # Variáveis de ambiente
└── package.json   # Dependências
```
