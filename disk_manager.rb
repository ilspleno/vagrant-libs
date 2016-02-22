# vi: set ft=ruby :
#
# Called by Vagrantfile, not a standalone script
#
require 'pp'

def create_asm_disks(vb, options)

	# Options:
	# 		prefix => name to prepend to disk volume
	# 		project => name to assign to all disks
	# 		create => flag to create or just attach 
	# 		num => number of disks to create
	# 		size => size of disks in GB
	# 		shareable => true if disks will be shared (RAC). If not they will be thin provisioned, otherwise have to be thick

	#pp options
	
	# Load default values
	project_name 	= options[:project] || "default_project"
	create		= options[:create] 
	shareable	= options[:shareable]

	diskport = 1
	diskpath=`VBoxManage list systemproperties | grep "Default machine folder" | awk ' { print $4; } '`.chomp

	options[:groups].each do |group|

		disk_prefix = group[:prefix] || 'default-prefix'
                num_disks   = group[:num]    || 1
                disk_size   = group[:size]   || 1

		(1..num_disks).each do |n|
			
			# Change path based on Windows vs. Linux
			if ENV['OS'].match /windows/i
				disk = diskpath + "\\#{project_name}_#{disk_prefix}_#{n}.vdi"
			else
				disk = diskpath + "/#{project_name}_#{disk_prefix}_#{n}.vdi"
			end

			# If we were asked to create disk, and it's not already there...
			if !File.exist?(disk.gsub /\\\\/, '\\') 
				if shareable
					variant='Fixed'
				else
					variant='Standard'
				end

				# Create the disks
				vb.customize ['createhd', '--filename', disk, '--size', disk_size * 1024, '--variant', variant]
				vb.customize ['modifyhd', disk, '--type', 'shareable'] if shareable
			end

			# Either way, attach the disk
			vb.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--device', 0, '--port', diskport, '--type', 'hdd', '--medium', disk]
			diskport += 1
		end

	end
end
