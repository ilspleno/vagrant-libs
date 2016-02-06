# vi: set ft=ruby :
#
# Called by Vagrantfile, not a standalone script

def create_asm_disks(config, vb, project_name, do_attach)

	diskport = 1
	diskpath=`VBoxManage list systemproperties | grep "Default machine folder" | awk ' { print $4; } '`.chomp

	# Create OCRVOTE disks
	(1..OCR_DISKS).each do |n|
		if ENV['OS'].match /windows/i 
			disk = diskpath + "\\ocrdisk_#{project_name}_#{n}.vdi"
		else
			disk = diskpath + "/ocrdisk_#{project_name}_#{n}"
		end

	       	
		if !do_attach or File.exist? (disk.gsub /\\\\/, '\\')
			# Just attach
			vb.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--device', 0, '--port', diskport, '--type', 'hdd', '--medium', disk]
			diskport += 1

		else
			# Create and attach
			vb.customize ['createhd', '--filename', disk, '--size', OCR_DISK_SIZE * 1024, '--variant', 'Fixed']
			vb.customize ['modifyhd', disk, '--type', 'shareable']
			vb.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--device', 0, '--port', diskport, '--type', 'hdd', '--medium', disk]
			diskport += 1
		end
	end

	# Create ASM disks
	(1..ASM_DISKS).each do |n|
		if ENV['OS'].match /windows/i 
			disk = diskpath + "\\asmdisk_#{project_name}_#{n}.vdi"
		else
			disk = diskpath + "/asmdisk_#{project_name}_#{n}"
		end

		if !do_attach or File.exist? (disk.gsub /\\\\/, '\\')
			vb.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--device', 0, '--port', diskport, '--type', 'hdd', '--medium', disk]
			diskport += 1
		else
			vb.customize ['createhd', '--filename', disk, '--size', ASM_DISK_SIZE * 1024, '--variant', 'Fixed']
			vb.customize ['modifyhd', disk, '--type', 'shareable']
			vb.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--device', 0, '--port', diskport, '--type', 'hdd', '--medium', disk]
			diskport += 1
		end
	end


end
