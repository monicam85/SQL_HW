#!flask/bin/python
from flask import Flask, jsonify, request, url_for, redirect, render_template
import requests
import datetime

import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session, mapper
from sqlalchemy import create_engine, desc

from sqlalchemy.ext.declarative import declarative_base 
from sqlalchemy import func

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def climate_home():
    errors = []
    if request.method == "POST":
        # get trip date entered
        try:
            start_date = request.form['start_date']
            end_date = request.form['end_date']
            if end_date:
                return redirect(url_for('.trip', start=start_date, end=end_date))
            else:
                return redirect(url_for('.trip', start=start_date))
        except:
            errors.append(
                "Unable to get URL. Please make sure it's valid and try again."
            )
            return render_template('index.html', errors=errors)

    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Welcome to the Climate App</title>

    </head>
    <body style="width: 880px; margin-left: 20px; background-color: lightblue;">
        <h2>Welcome to the Climate App</h2>
        <p><a href="./api/v1.0/precipitation">Query for the dates and temperature observations
        from the last year</a></p>
        
        <p><a href="./api/v1.0/stations">list of stations from the dataset</a></p>

        <p><a href="./api/v1.0/tobs">list of Temperature Observations (tobs) 
        for the previous year</a></p>
        <div class="container">
            <h3>Temperature Analysis</h3>
            <p style="text-indent: 20px;">When given the start only, calculates TMIN, TAVG, and TMAX for all dates greater 
            than and equal to the start date.</p>
            <p style="text-indent: 20px;">When given the start and the end date, calculates the TMIN, TAVG, and TMAX for dates
            between the start and end date inclusive.
            </p>
            <form role="form" method='POST' action='/'>
                <div class="form-group">
                    <input type="text" name="start_date" class="form-control" id="start_date-box" placeholder="Enter trip start date..." style="max-width: 300px;" autofocus required>
                    <input type="text" name="end_date" class="form-control" id="end_date-box" placeholder="Enter trip end date..." style="max-width: 300px;">                
                    <p>Format: YYYY-MM-DD</p>
                    <p></p>
                </div>
                <button type="submit" class="btn btn-default">Submit</button>
            </form>
            <br>
        </div>

    </body>
    </html>
     """

@app.route('/api/v1.0/precipitation')
def precipitation():
    """Query for the dates and temperature observations from the last year.
    Convert the query results to a Dictionary using date as the key and tobs as the value.
    Return the json representation of your dictionary."""
    query = session.query(measurement).order_by(measurement.date) \
            .filter(func.date(measurement.date).between(start_date, end_date))
    dictlist = []
    for row in query:
        keys =[(row.date).isoformat()]
        values = [row.prcp]
        dictlist.append(dict(zip(keys, values)))
    return jsonify(dictlist)
    

@app.route('/api/v1.0/stations')
def stations():
    """Return a json list of stations from the dataset."""
    keys = ['station', 'name']
    query = session.query(station).all()
    return jsonify(query2DictList(query, keys))


@app.route('/api/v1.0/tobs')
def tobs():
    """Return a json list of Temperature Observations (tobs) for the previous year"""
    keys = ['date', 'tobs']
    query = session.query(measurement).order_by(measurement.date) \
            .filter(func.date(measurement.date).between(start_date, end_date))
    return jsonify(query2DictList(query, keys))


@app.route('/api/v1.0/<start>')
@app.route('/api/v1.0/<start>/<end>')
def trip(start, end=None):
    """Return a json list of the minimum temperature, the average temperature, and the max temperature for a given start or start-end range.
    When given the start only, calculate TMIN, TAVG, and TMAX for all dates greater than and equal to the start date.
    When given the start and the end date, calculate the TMIN, TAVG, and TMAX for dates between the start and end date inclusive."""
    yyyy, mm, dd = start.split('-')
    start_date = datetime.date(int(yyyy), int(mm), int(dd))
    if end:
        yyyy, mm, dd = end.split('-')
        end = datetime.date(int(yyyy), int(mm), int(dd))
    results = calc_temps(start_date, end)
    return jsonify(results)

def query2DictList(result, keys):
    dictlist=[]
    for row in result:
        try:
            values = [(row.date).isoformat(), row.tobs]
        except:
            values = [row.station, row.name]
        dictlist.append(dict(zip(keys, values)))
    return dictlist

def calc_temps(start_date, end_date=None):
    keys = ['min_temp', 'avg_temp', 'max_temp']
    if end_date == None:
        end_date =  session.query(measurement.date).order_by(measurement.date)[-1:]
        end_date = end_date[0].date
    query = session.query(measurement, func.count(measurement.tobs).label('count'),
                                   func.max(measurement.tobs).label('max_temp'),
                                   func.min(measurement.tobs).label('min_temp'),
                                   func.sum(measurement.tobs).label('total_temp')
                         ).filter(func.date(measurement.date).between(start_date, end_date))
    avg_temp = query[0].total_temp / query[0].count
    values = [query[0].min_temp, avg_temp, query[0].max_temp]
    results = dict(zip(keys, values))
    return results


if __name__ == '__main__':
    engine = create_engine('sqlite:///hawaii.sqlite')
    Base = automap_base()
    Base.prepare(engine, reflect = True)
    measurement = Base.classes.measurement
    station = Base.classes.station
    session = Session(engine)
    #end_date =  session.query(measurement.date).order_by(measurement.date)[-1:]
    # determine 12 months ago from today
    end_date = datetime.date.today() - datetime.timedelta(weeks=52)
    start_date = end_date - datetime.timedelta(weeks=52)

    app.run()