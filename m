From: "Christian Groessler" <cpg@aladdin.de>
Date: Tue, 24 Oct 2000 09:53:17 +0000
Subject: Re: [Linux-ia64] Making a CD that is readable under efi
Message-Id: <marc-linux-ia64-105590678205614@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205609@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205609@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org




Sorry, when I jump in here...

On 10/24/2000 01:04:31 AM GMT Uros Prestor wrote:
>
>Create ISO image with mkisofs (we use version 1.13a05) as follows:
>
>     mkisofs  -no-emul-boot -b boot.img -c boot.catalog \
>         -R -T -J -o cdrom.img /path/to/the/cd/root
>
>When you burn the ISO image be sure to disable MS Jolliet extensions.

What do you mean by that? The "-J" option to mkisofs selects
adding the Joliet extension. AFAIL one cannot specify it in
the burn program (cdrecord in my case).

regards,
chris




