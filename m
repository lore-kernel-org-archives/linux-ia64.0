From: "vamsi krishna" <vamsi.krishnak@gmail.com>
Date: Thu, 08 Jun 2006 17:33:13 +0000
Subject: Re: Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 ]]
Message-Id: <3faf05680606081021h3c08a012tb9fcff78807307b5@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hell Andreas,

>
> > Looks like If I dont overwrite the RSE backing store fclose on my open
> > files seem to crash when I restore my program.
>
> You also need to make sure that all function descriptors end up at the
> very same address.
>

Do you mean file descriptors?
