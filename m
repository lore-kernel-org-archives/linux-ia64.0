From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 04 Jan 2010 23:50:39 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be  kernel-related?
Message-Id: <201001041650.39862.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Monday 04 January 2010 03:40:46 pm =C9meric Maschino wrote:
> Indeed, it seems that something is going wrong with AGP GART. Here are
> the relevant lines of the dmesg output:
>=20
> [=A0=A0 12.652322] Linux agpgart interface v0.103
> [=A0=A0 12.715735] Unable to handle kernel NULL pointer dereference
> (address 0000000000000003)
> [=A0=A0 12.715784] modprobe[895]: Oops 8804682956800 [1]
> [=A0=A0 12.715819] Modules linked in: hp_agp(+) agpgart snd_fm801
> snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm
> snd_page_alloc snd_tea575x_tuner videodev v4l1_compat
> v4l2_compat_ioctl32 i2c_core snd_opl3_lib snd_hwdep snd_mpu401_uart
> snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer
> snd_seq_device snd fm801_gp soundcore gameport evdev ext4 mbcache jbd2
> crc16 sd_mod crc_t10dif usbhid hid ide_cd_mod cdrom ide_pci_generic
> ata_generic libata tg3 mptspi mptscsih e100 ohci_hcd cmd64x libphy
> mptbase scsi_transport_spi scsi_mod mii ide_core ehci_hcd usbcore
> nls_base [last unloaded: scsi_wait_scan]
> [=A0=A0 12.716925]
> [=A0=A0 12.716926] Pid: 895, CPU 0, comm:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 modprobe
> [=A0=A0 12.716988] psr : 00001010085a6010 ifs : 8000000000000712 ip=A0 :
> [<a000000202b10200>]=A0=A0=A0 Not tainted (2.6.32-trunk-mckinley)
> [=A0=A0 12.717044] ip is at zx1_gart_probe+0xd0/0xcc0 [hp_agp]

This definitely looks like a kernel problem.  I tried to reproduce it,
but regrettably, the current upstream kernel croaks before I get that
far with this:

  Unable to handle kernel paging request at virtual address a00000010400ab00
  swapper[0]: Oops 8804682956800 [1]
  Modules linked in:

  Pid: 0, CPU 0, comm:              swapper
  psr : 00001010084a6018 ifs : 8000000000000288 ip  : [<a000000100ed8d60>] =
   Not tainted (2.6.33-rc2-00302-gc5974b8)
  ip is at proc_net_ns_init+0x100/0x160

Guess I'll have to sort through that problem first.

Bjorn
