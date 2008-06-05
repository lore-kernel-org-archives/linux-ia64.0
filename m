From: Bernhard Walle <bwalle@suse.de>
Date: Thu, 05 Jun 2008 08:01:54 +0000
Subject: Re: kdump regression: /proc/vmcore is 0 after kdump
Message-Id: <20080605100154.1e7142b0@halley.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0806050058u3159e7b5x3113f63b3e0f3d8f@mail.gmail.com>
In-Reply-To: <3877989d0806050058u3159e7b5x3113f63b3e0f3d8f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Luming Yu [2008-06-05 15:58]:
>
> I tested mainline kernel from 2.6.20 to 2.6.26-rc4 on my tiger4..
> whatever I try, /proc/vmcore is always 0 !

Do you use kexec-tools-testing branch (maintained by Simon Horms) in
userspace?


Bernhard

