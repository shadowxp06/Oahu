process.env.NODE_ENV = 'dev';

//let mongoose = require("express");

//Require the dev-dependencies
let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../server');
let should = chai.should();

describe('/GET ex', () => {
    it('it should do something..', (done) =>
    chai.request(server).get('/api/v1/user').end((err,res) => {
        res.should.have.status(200);
        res.body.should.be.a('array'); //???
        res.body.length.should.be.eql(0);
        done();
    }))
});
