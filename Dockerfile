FROM ros:humble-ros-base

WORKDIR /opt/rmf

# Install dependencies
RUN apt-get update && apt-get install -y python3-pip && \
    pip3 install websockets websocket-client requests

# Clone the repository
WORKDIR /opt/rmf/src
RUN mkdir -p /kone-ros-api

RUN git clone https://github.com/open-rmf/rmf_internal_msgs.git --branch main --single-branch --depth 1
COPY . kone-ros-api/

# Verify the contents
RUN ls -la /opt/rmf/src/kone-ros-api

# Setup the workspace
WORKDIR /opt/rmf
RUN . /opt/ros/$ROS_DISTRO/setup.sh && apt-get update && rosdep update --rosdistro $ROS_DISTRO
RUN . /opt/ros/$ROS_DISTRO/setup.sh && rosdep install -y --from-paths /opt/rmf/src/kone-ros-api --ignore-src

# Build the workspace
RUN . /opt/ros/$ROS_DISTRO/setup.sh && colcon build --packages-select kone_ros_api && colcon build --packages-select rmf_lift_msgs

# Ensure the entrypoint script sources the ROS setup
RUN echo 'source /opt/rmf/install/setup.bash' >> /ros_entrypoint.sh

# Ensure proper permissions for entrypoint
RUN chmod +x /ros_entrypoint.sh

WORKDIR /opt/rmf/
ENTRYPOINT ["/ros_entrypoint.sh"]

