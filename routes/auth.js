/**
 * Created by joaodiogofalcao on 28/02/15.
 */
var Controller = {
    isLoggedIn: function (req, res, next) {
        if(req && req.session && req.session.auth && req.session.userName){
            next();
        }else
            return res.redirect('/login');
    },
    hasAccess: function (req, res, next) {
        next();
    },
    login: function (req, res, next) {
        var Tables = req.db;

        Tables.User().login({userName: req.body.userName, password: req.body.password})
            .success(function(status){
                console.log(status);
                if(status == 200){
                    req.session.auth = true;
                    req.session.userName = req.body.userName;

                    console.info('Login USER: ' + req.body.userName);
                    return res.status(200).json({username: req.body.userName});
                }else{
                    return res.status(401).json("Invalid Email/Password.");
                }
            })
            .error(function(err){
                next(err);
            });
    },
    logout: function (req, res, next) {
        console.info('Logout USER: ' + req.session.userName);
        req.session.destroy(function(err){
            if(!err){
                res.redirect('/login');
            }else{
                res.status(400).json(err);
            }

        });
    },
    signup: function (req, res, next) {
        var required = ['userName', 'password'];
        if(!checkParameters(req.body, required)){
            return res.status(400).json('Invalid parameters. ('+required.toString()+')');
        }


        req.db.User().create({userName: req.body.userName, password: req.body.password})
            .success(function(user){
                res.status(201).json(user.toJSON());
            })
            .error(function(err){
                if(err == 200)
                    return res.status(401).json("User Already Exists.")
                next(err);
            })

    }

}
var checkParameters = function(params, reqParams) {
    for (var i in reqParams){
        if(typeof reqParams[i] != 'function')
            if(params[reqParams[i]] === undefined) return false;
    }
    return true;
};

module.exports = Controller;
