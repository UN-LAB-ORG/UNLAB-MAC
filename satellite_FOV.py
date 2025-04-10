import Objects.room as room
import Objects.mirror as mirror
import plotter

# Setup Room Parameters
room_l = 500
room_w = 500
room_h = 0  # 2D model for now.
room_edge = 5

# def __init__(self, length, angleTilt,c_x,c_y,id ):
mirrors = [mirror.mirror(12, 150, 10, 20), mirror.mirror(12, 30, -10, 20), mirror.mirror(12, 0, 0, 20)]

num_mirrors = len(mirrors)

# Setup Simulation Room
simulation_room = room.room(room_l, room_w, "Square")
simulation_room.setup_mirrors_in_room(mirrors, num_mirrors)
simulation_room.setup_fov_generic(mirrors, num_mirrors)
plotter.plot_fov(simulation_room, mirrors)
