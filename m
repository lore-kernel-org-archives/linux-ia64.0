From: William Lee Irwin III <wli@holomorphy.com>
Date: Tue, 14 Sep 2004 16:52:06 +0000
Subject: Re: Oops in free_page_and_swap_cache on 2.6.9-rc2
Message-Id: <20040914165206.GW9106@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1095176571.1762.14.camel@mulgrave>
In-Reply-To: <1095176571.1762.14.camel@mulgrave>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 14, 2004 at 11:42:45AM -0400, James Bottomley wrote:
> I get this on a HP zx2000:
> Unable to handle kernel paging request at virtual address
> a0007fffc7900000
> gcc[14948]: Oops 11012296146944 [4]
> Modules linked in: af_packet forte ac97_codec ehci_hcd aic79xx e1000
> tulip cmd64x ide_core usbhid ohci_hcd usbcore snd_fm801 snd_pcm
> snd_page_alloc snd_tea575x_tuner videodev snd_ac97_codec snd_opl3_lib
> snd_timer snd_hwdep snd_mpu401_uart snd_rawmidi snd_seq_device snd
> soundcore ext2 ext3 jbd mbcache sd_mod qla1280 mptscsih mptbase aic7xxx
> sym53c8xx scsi_transport_spi scsi_mod

This sound like pfn_to_page() broke again...


-- wli
