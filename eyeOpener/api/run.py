from api import start_app

if __name__ == '__main__':
    app = start_app()
    app.run(debug=True, host='0.0.0.0', port=5000)
