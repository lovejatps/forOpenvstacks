ISOfilename=win2012.ISO
imagename=win2012.img
echo "please select number for---1:Create images;2:Setup system;3:Install networking"
read tmp
if [ ${tmp} -eq 1 ]; then
#Create one image for system files containing
qemu-img create -f raw ${imagename} 7G
qemu-img info ${imagename}
fi
if [ ${tmp} -eq 2 ]; then
#Setup system into image
kvm -m 2048 -cdrom $(pwd)/${ISOfilename} -drive file=$(pwd)/${imagename},if=virtio,boot=on -fda virtio-win-1.1.16.vfd -boot d -nographic -vnc :0
fi
if [ ${tmp} -eq 3 ]; then
#Boot up virtul machine`s network service
kvm -m 2048 -drive file=$(pwd)/${imagename},if=virtio,boot=on -cdrom virtio-win-0.1-81.iso -net nic,model=virtio -net user -boot c -nographic -vnc :0
fi
