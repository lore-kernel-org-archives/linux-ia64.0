From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Wed, 05 May 2004 17:10:13 +0000
Subject: Re: [PATCH] boot parameters mem and max_addr
Message-Id: <20040505101013.54f9a086.rddunlap@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40991DE7.7010401@hp.com>
In-Reply-To: <40991DE7.7010401@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 05 May 2004 13:01:27 -0400 Robert Picco wrote:

| The boot parameter "mem=" will behave like it does for other LINUX 
| architectures.   The boot parameter "max_addr" can be used to limit the 
| maximum physical address like the old "mem=" feature.
| 

So max_addr needs to be documented in Documentation/kernel-parameters.txt.

--
~Randy
(Again.  Sometimes I think ln -s /usr/src/linux/.config .signature) -- akpm
