From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 16 Oct 2003 23:19:54 +0000
Subject: Re: type 95 for .text?
Message-Id: <marc-linux-ia64-106634674805457@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106634361902844@msgid-missing>
In-Reply-To: <marc-linux-ia64-106634361902844@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 16 Oct 2003 15:33:27 -0700, 
Grant Grundler <iod00d@hp.com> wrote:
>
>make install_modules for 2.4.23-pre6:
> ...
>find kernel -path '*/pcmcia/*' -name '*.o' | xargs -i -r ln -sf ../{} pcmcia
>if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.4.23-pre6; fi
>depmod: Modules compiled with -mconstant-gp cannot be loaded of type 95 for .text                                                                               
>depmod: Modules compiled with -mconstant-gp cannot be loaded of type 95 for .text
>...
>depmod: depmod obj_relocate failed                                              
>
>using	modules-init-tools 0.9.15-pre2-2 
>	gcc-3.3		3.3.2-0pre4
>	binutils	2.14.90.0.6-3	 (also tried -4)
>
>
>Anyone have a clue what this is about?

One or more of your modules was compiled with the wrong flags, it used
the kernel flags instead.  The ia64 kernel is compiled with
-mconstant-gp, modules must not use that flag.  Which module did you
add yourself?

