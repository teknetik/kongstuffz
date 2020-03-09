from flask import Flask, jsonify
import pymysql

app = Flask(__name__)

class Database:
    def __init__(self):
        host = "127.0.0.1"
        user = "kong"
        password = "kong"
        db = "sakila"
        self.con = pymysql.connect(host=host, user=user, password=password, db=db, cursorclass=pymysql.cursors.
                                   DictCursor)
        self.cur = self.con.cursor()
    def list_films(self):
        self.cur.execute("SELECT title,release_year FROM film ORDER BY release_year;")
        result = self.cur.fetchall()
        return result

@app.route("/")
def main():

        def db_query():
            db = Database()
            emps = db.list_films()
            return emps

        res = db_query()
        return jsonify(result=res)

if __name__ == "__main__":
    app.run(host= '0.0.0.0')