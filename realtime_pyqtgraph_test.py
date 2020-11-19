from pyqtgraph.Qt import QtGui, QtCore
import numpy as np
import pyqtgraph as pg

#QtGui.QApplication.setGraphicsSystem('raster')
app = QtGui.QApplication([])
#mw = QtGui.QMainWindow()
#mw.resize(800,800)

def generate_graph(win):
    plot = win.addPlot(title="Updating plot")
    curve = plot.plot(pen='y')
    timer = QtCore.QTimer()
    def update():
        curve.setData(np.random.normal(size=(512)))

    timer.timeout.connect(update)
    timer.start(1000)
    timer.setInterval(50)
    return timer

win = pg.GraphicsLayoutWidget(show=True, title="Basic plotting examples")
win.resize(600,400)
win.setWindowTitle('Plot')
pg.setConfigOptions(antialias=True)

timer1 = generate_graph(win)
timer2 = generate_graph(win)
timer3 = generate_graph(win)
timer4 = generate_graph(win)

app.instance().exec()