From: Qin Xiaohan <xhqin@redflag-linux.com>
Date: Fri, 12 Aug 2005 01:47:11 +0000
Subject: Re: efibootmgr 0.5.2.2 for testing
Message-Id: <200508120947.11103.xhqin@redflag-linux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050811181028.GA12525@lists.us.dell.com>
In-Reply-To: <20050811181028.GA12525@lists.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

Dear Matt:
	I just do simply testing,It works fine,I will ask our developer 
Starney(zxni@redflag-linux.com) do more testing and give you a report later.
On Friday 12 August 2005 02:10, Matt Domsch wrote:
> I've put out a test version of efibootmgr, I'd appreciate people with
> the capabilities to test this and report back.  I'm hoping this fixes
> the cases reported where a 32-bit efibootmgr on a 32-bit kernel wasn't
> working correctly, but I don't have such equipment to test myself.  If
> it's all good, I'll release it as 0.5.3.
>
> Rogerio, I gave -@ a long option --append-binary-args, rather than
> --@, to be consistent with the other long options.
>
> Thanks to Brad Chen and Ping Wei from Intel for their debugging and patch
> suggestions.
>
>
> * Thu Aug 11 2005 Matt Domsch <Matt_Domsch@dell.com>
> - applied patch from Rogerio Timmers which adds a new option -@ <file>,
>   which takes extra variable parameters from <file>, or - from stdin.
>   This lets you pass binary (non-unicode, non-ascii) formatted options to
>   your bootloader.
> - cleaned up Rogerio's patch some.
> - moved definition of _FILE_OFFSET_BITSd into Makefile and out of the
>   individual .c files.  This fixes a bug reported by Red Flag, where
>   variable data was getting incorrectly set with a 32-bit copy of
>   efibootmgr on a 32-bit kernel.
> - made efi_variable_t.DataSize be an unsigned long to match the kernel.
>   This lets a 32-bit copy of efibootmgr run on a 32-bit kernel.  This
>   means you've got to have a 32-bit efibootmgr on a 32-bit kernel, and a
>   64-bit efibootmgr on a 64-bit kernel, but since efi_status_t is also a
>   long, this was really going to be the case anyway.
> - valgrind caught the app exiting without freeing some malloc'd
>   structures, fix that.
> - v0.5.2.2 released for testing
>
>
> http://linux.dell.com/efibootmgr/testing/efibootmgr-0.5.2.2.tar.gz
> http://linux.dell.com/efibootmgr/testing/efibootmgr-0.5.2.2.tar.gz.sign
>
>
> Thanks,
> Matt

-- 
Best Regards

Qin Xiaohan
Product Manager 
Red Flag Software Co., Ltd.
Tel:(8610)82656655 Ext.2637
Fax:(8610)82658096
Address: 6/F, Zijin Bldg., 68 Wanquanhe Rd.,
              Haidian Dist., Beijing, P.R.China
Zip:100086
Email:xhqin@redflag-linux.com
Http://www.redflag-linux.com
