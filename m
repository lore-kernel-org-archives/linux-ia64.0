From: "Alberto Munoz" <amunoz@vmware.com>
Date: Mon, 03 Nov 2003 17:53:45 +0000
Subject: RE: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106788207929466@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



> Hi,
> 
> I just wondered if a speculative load hitting a cache or memory
> error does cause an exception on IA64 ? 
> 

As far as I know, the answer is yes. The processor has no way of
distinguishing speculative vs. non-speculative accesses on the buses or
caches.

Bert Munoz

> Thanks
> 
> Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com 
>  VNET 521-8213
> Principal Engineer      Silicon Graphics          Home Office 
> (+33) 1 3047 4127
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


