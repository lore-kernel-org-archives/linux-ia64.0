From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 23 Jun 2004 06:14:01 +0000
Subject: Re: Is vfat fs case sensitive in 2.6.7?
Message-Id: <20040623061401.GA8337@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622224302.GA953@lucon.org>
In-Reply-To: <20040622224302.GA953@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 23, 2004 at 09:11:26AM +1000, Keith Owens wrote:
> On Tue, 22 Jun 2004 15:43:02 -0700, 
> "H. J. Lu" <hjl@lucon.org> wrote:
> >Under 2.4, I got
> >
> >[root@gnu-4 efi]# cd /boot/efi/
> >[root@gnu-4 efi]# touch foo
> >[root@gnu-4 efi]# ls -l FOO
> >-rwxr-xr-x    1 root     root            0 Jun 22 15:41 FOO
> >[root@gnu-4 efi]#
> >
> >Under 2.6.7, I got
> >
> >[root@gnu-2 efi]# cd /boot/efi/
> >[root@gnu-2 efi]# touch foo
> >[root@gnu-2 efi]# ls -l FOO
> >ls: FOO: No such file or directory
> >[root@gnu-2 efi]#
> 
> Works for me on 2.6.7.
> 
> # cd /boot/efi
> # touch foo
> # ls -il FOO foo
>     111 -rwxr-xr-x    1 root     root            0 Jun 23 09:08 foo
>     111 -rwxr-xr-x    1 root     root            0 Jun 23 09:08 FOO
> 

I have

CONFIG_NLS_DEFAULT="utf8"

in .config. Does it make a difference?


H.J.
