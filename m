From: Rich Altmaier <richa@engr.sgi.com>
Date: Wed, 29 May 2002 17:18:43 +0000
Subject: Re: [Linux-ia64] NTP broken?
Message-Id: <marc-linux-ia64-105590701905614@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905591@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905591@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, FYI, I asked our hardware designers about current oscillator
accuracy and was a bit suprised to learn that one pays a
premium price today to get 300ppm.  600ppm can happen
in lower cost units.

FYI, Rich



David Mosberger wrote:
> 
> >>>>> On Tue, 28 May 2002 15:48:49 -0700, "Luck, Tony" <tony.luck@intel.com> said:
> 
>   Tony> I compared a HZ0 kernel with a HZ24 kernel on a BigSur
>   Tony> ... it made no obvious difference, both kernels lost time at
>   Tony> about 38.5 milliseconds/minute relative to a machine running
>   Tony> NTP.
> 
> Hmmh, interesting data.  So the rate is 633ppm.  Does anyone know what
> the crystals on the BigSurs are rated at?
> 
>         --david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

