# Description:
#   get a random item from a group
#
# Dependencies:
#	None
#
# Configuration:
#	None
#
# Commands:
#   Hubot random create (group) - create a new group
#	Hubot random add (item) to (group) - add a new item item to group
#	Hubot random get (group) - get a random item from group
#	Hubot random delete group (group) - delete a group
#	Hubot random delete item (item) from (group) - remove item from group
#	Hubot random list groups - list all groups
#	Hubot random list items (group) - list all items from group
#
# Author:
#   KingOfBananas
#

class GroupManager
	constructor: (@robot) ->
		storageLoaded = =>
			@storage = @robot.brain.data.bsRandom ||= {
				groups: {}
			}
			@robot.logger.debug "Random Data Loaded: " + JSON.stringify(@storage, null, 2)

		@robot.brain.on "loaded", storageLoaded
		storageLoaded()

	create: (group) ->
		if @validate(group)
			@storage.groups[group] ||= []
			@robot.brain.save()
			return true
		false

	add: (group, item) ->
		if @validateItem(group, item)
			@storage.groups[group] ||= []
			@storage.groups[group].push(item)
			@robot.brain.save()
			return true
		false

	all: (group) ->
		if @validate(group)
			@storage.groups[group] ||= []
			@storage.groups[group]
		else
			[]

	groups: () ->
		@storage.groups

	random: (group) ->
		if @validate(group)
			@storage.groups[group] ||= []
			@storage.groups[group][Math.floor(Math.random() * @storage.groups[group].length)];
		else
			return ""

	erase: (group) ->
		delete @storage.groups[group]
		return true

	remove: (group, item) ->
		if @validate(group)
			@storage.groups[group] ||= []
			index = @storage.groups[group].indexOf(item)
			if index isnt -1
				@storage.groups[group].splice(index, 1)
				@robot.brain.save()
				return true
		false

	validate: (group) ->
		group != ""

	validateItem: (group, item) ->
		@validate(group) && item != ""


module.exports = (robot) ->
	groupManager = new GroupManager(robot)

	robot.respond /random create (.*)/i, (msg) ->
		group = msg.match[1].trim().toLowerCase()
		if groupManager.create(group)
			msg.send "new group \"#{group}\" created" 

	robot.respond /random add (.*) to (.*)/i, (msg) ->
		item = msg.match[1].trim().toLowerCase()
		group = msg.match[2].trim().toLowerCase()
		if groupManager.add(group, item)
			msg.send "#{item} added to #{group}"

	robot.respond /random get (.*)/i, (msg) ->
		group = msg.match[1].trim().toLowerCase()
		msg.send groupManager.random(group)

	robot.respond /random delete group (.*)/i, (msg) ->
		group = msg.match[1].trim().toLowerCase()
		if groupManager.erase(group)
			msg.send "#{group} deleted"

	robot.respond /random delete item (.*) from (.*)/i, (msg) ->
		item = msg.match[1].trim().toLowerCase()
		group = msg.match[2].trim().toLowerCase()
		if groupManager.remove(group, item)
			msg.send "#{item} deleted from #{group}"

	robot.respond /random list groups/i, (msg) ->
		groups = []
		for name of groupManager.groups()
			groups.push(name)
		if groups.length > 0
			msg.send groups.join(", ")
		else
			msg.send "no groups have been created"

	robot.respond /random list items (.*)/i, (msg) ->
		group = msg.match[1].trim().toLowerCase()
		items = groupManager.all(group)
		if items.length > 0
			msg.send items.join(", ")
		else
			msg.send "no items have been added to #{group}"
