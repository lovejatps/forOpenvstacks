ISOfilename=ubuntu-14.04.2-server-amd64.iso
imagename=ubuntu.img
echo "please select number for---0:setup Envirement;1:Create images;2:Setup system;3:Install networking"
read tmp
if [ ${tmp} -eq 0 ]; then
#Setup qemu-kvm / virt envirement
apt-get install qemu-kvm libvirt-bin virt-manager bridge-utils
fi
if [ ${tmp} -eq 1 ]; then
#Create one image for system files containing
qemu-img create -f raw ${imagename} 20G
qemu-img info ${imagename}
fi
if [ ${tmp} -eq 2 ]; then
#Setup system into image
kvm -m 2048 -cdrom $(pwd)/${ISOfilename} -drive file=$(pwd)/${imagename},if=virtio,boot=on -fda virtio-win-1.1.16.vfd -boot d -nographic -vnc :0
fi
if [ ${tmp} -eq 3 ]; then
#Boot up virtul machine`s network service
#kvm -m 2048 -drive file=$(pwd)/${imagename},if=virtio,boot=on -cdrom virtio-win-0.1-81.iso -net nic,model=virtio -net user -boot c -nographic -vnc :0
virt-install --name ubuntutest --hvm --ram 1024 --vcpus 1 --disk path=$(pwd)/${imagename},size=10  --network network:default --accelerate  --vnc --vncport=5911 --cdrom #(pwd)/${ISOfilename} -d
fi
