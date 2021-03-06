import * as express from 'express';
import routes from './routes';

createConnection()
    .then(async (connection) => {
        const app = express();

        app.use('/', routes);

        app.listen(3000, () => {
            console.log('API started on port 3000!');
        });
    })
    .catch((error) => console.log(error));
