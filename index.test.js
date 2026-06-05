import { app, server } from '.'
import request from 'supertest'
import User from './users/model.js'
import sequelize from './shared/database/database'
import { Sequelize } from 'sequelize'

describe('User', () => {
    let data
    let mockedSequelize

    beforeEach(async () => {
        data = {
            "dni": "1234567890",
            "name": "Test"
        }
        jest.spyOn(console, 'log').mockImplementation(jest.fn())
        jest.spyOn(sequelize, 'log').mockImplementation(jest.fn())
        mockedSequelize = new Sequelize({
            database: '<any name>',
            dialect: 'sqlite',
            username: 'root',
            password: '',
            validateOnly: true,
            models: [__dirname + '/models'],
        })
        await mockedSequelize.sync({ force: true })
    })

    afterEach(async () => {
        jest.clearAllMocks()
        await mockedSequelize.close()
    })

    afterAll(async () => {
        server.close()
    })

    // ── GET /api/users ──────────────────────────────────────────────────────
    test('Get users', async () => {
        jest.spyOn(User, 'findAll').mockResolvedValue([data])
        const response = await request(app).get('/api/users')

        expect(response.status).toBe(200)
        expect(response.body).toEqual([data])
    })

    // ── GET /api/users/:id ──────────────────────────────────────────────────
    test('Get user', async () => {
        jest.spyOn(User, 'findByPk').mockResolvedValue({...data, "id": 1})
        const response = await request(app).get('/api/users/1')

        expect(response.status).toBe(200)
        expect(response.body).toEqual({...data, "id": 1})
    })

    test('Get user - not found returns 404', async () => {
        jest.spyOn(User, 'findByPk').mockResolvedValue(null)
        const response = await request(app).get('/api/users/99')

        expect(response.status).toBe(404)
        expect(response.body).toHaveProperty('error')
    })

    test('Get user - non-numeric id returns 400', async () => {
        const response = await request(app).get('/api/users/abc')

        expect(response.status).toBe(400)
        expect(response.body).toHaveProperty('errors')
    })

    // ── POST /api/users ─────────────────────────────────────────────────────
    test('Create user', async () => {
        jest.spyOn(User, 'findOne').mockResolvedValue(null)
        jest.spyOn(User, 'create').mockResolvedValue({...data, "id": 1})
        const response = await request(app).post('/api/users').send(data)

        expect(response.status).toBe(201)
        expect(response.body).toEqual({...data, "id": 1})
    })

    test('Create user - already exists returns 400', async () => {
        jest.spyOn(User, 'findOne').mockResolvedValue({...data, "id": 1})
        const response = await request(app).post('/api/users').send(data)

        expect(response.status).toBe(400)
        expect(response.body).toHaveProperty('error')
    })

    test('Create user - missing required fields returns 400', async () => {
        const response = await request(app).post('/api/users').send({})

        expect(response.status).toBe(400)
        expect(response.body).toHaveProperty('errors')
    })
})
