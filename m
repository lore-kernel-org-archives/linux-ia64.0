From: Matt_Domsch@Dell.com
Date: Mon, 06 Aug 2001 15:19:42 +0000
Subject: RE: [Linux-ia64] efibootmgr-0.3.3 release
Message-Id: <marc-linux-ia64-105590693006002@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693006000@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693006000@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Goes bang for me...  assuming efichar_strlen() is supposed to return
> the length in efichars, not bytes, the following fixes it.  
> In any case
> a null is needed on the end of buffer[].

Good catch.  It hadn't blown up on me, but your patch is correct, and I've
applied it.  Thanks!!

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

