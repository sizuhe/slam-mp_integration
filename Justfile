# Show available commands
help:
	@just --list





@topics:
	ros2 topic list

@topic_info topic:
	ros2 topic info {{topic}}

@echo_topic topic:
	ros2 topic echo {{topic}}

@odom:
	ros2 topic echo /odom --field pose.pose.position



@gz_topics:
	gz topic -l

@kill:
	#!/usr/bin/env bash
	pkill -f ros2 || true
	pkill -f gz || true
	pkill -f "gz sim" || true
	pkill -f px4 || true
	pkill -f MicroXRCEAgent || true
