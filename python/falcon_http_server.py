import falcon, gunicorn.app.base

class Runner(gunicorn.app.base.BaseApplication):
    def __init__(self, app):
        self.app = app
        super().__init__()

    def load_config(self):
        self.cfg.set('bind', '0.0.0.0:8080')

    def load(self):
        return self.app

class Res:
    def on_get(self, req, resp):
        resp.content_type = falcon.MEDIA_HTML
        resp.data = b'<html><body>hello</body></html>'

def main():
    app = falcon.API()
    res = Res()
    app.add_route('/', res)
    Runner(app).run()

if __name__ == '__main__':
    main()
