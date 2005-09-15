From: Khalid Aziz <khalid_aziz@hp.com>
Date: Thu, 15 Sep 2005 16:26:13 +0000
Subject: Re: [PATCH] Updated /proc/iomem patch
Message-Id: <1126801573.21053.3.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1126716323.29344.55.camel@lyra.fc.hp.com>
In-Reply-To: <1126716323.29344.55.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-09-14 at 10:45 -0600, Khalid Aziz wrote:
> Here is an updated patch that makes /proc/iomem include information
> about system RAM as well. This makes /proc/iomem on ia64 look like it
> does on x86 and also enables kexec-tools to work on ia64.
> 

I am not sure if marking the memory allocated by bootloader for kernel,
inital ramdisk, EFI memory map and boot parameters as "reserved"
in /proc/iomem is the right thing to do. I have done it this way in the
patch but I would appreciate other opinions.

-- 
Khalid

==================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

