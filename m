From: Keith Owens <kaos@sgi.com>
Date: Tue, 25 Jan 2005 04:44:26 +0000
Subject: Re: Announce: kdb v4.4 is available for kernel 2.6.10
Message-Id: <15313.1106628266@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Tue, 25 Jan 2005 09:55:55 +0530."
             <51a933b50501242025645ef27a@mail.gmail.com> 
References: <12956.1085377697@kao2.melbourne.sgi.com>
In-Reply-To: <12956.1085377697@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Saravanan s <saravanan.mainker@gmail.com>
Cc: kdb@oss.sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 25 Jan 2005 09:55:55 +0530, 
Saravanan s <saravanan.mainker@gmail.com> wrote:
>Hi Keith,
>
>> I have no hardware to test on, so I have
>> to rely on HP to keep the USB patches in KDB up to date. 
>
>Does that mean that there is USB support for KDBv4.4 for kernel 2.6 
>for i386 machines? Or the patch for i386 also comes from the HP guys.

All the USB console patches for kdb came from HP, both i386 and ia64.
Neither work in 2.6 kernels at the moment.

