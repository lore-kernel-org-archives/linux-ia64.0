From: Francois-Xavier Kowalski <francois-xavier_kowalski@hp.com>
Date: Wed, 23 Jan 2002 11:27:37 +0000
Subject: Re: [Linux-ia64] native ia64 32-bits compile & run on linux-ia64?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030804080000060806090200"
Message-Id: <marc-linux-ia64-105590698805918@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805893@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805893@msgid-missing>
To: linux-ia64@vger.kernel.org

--------------030804080000060806090200
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Jes Sorensen wrote:

>>>>>>"David" == David Mosberger <davidm@hpl.hp.com> writes:
>>>>>>
>
>David> I think one point that hasn't been made so far is that we
>David> actively discourage supporting an ILP32 data model for IA-64
>David> Linux to avoid splitting ia64 linux into two different worlds
>David> (32-bit and 64-bit world).  If we supported ILP32, it's very
>David> likely that some ISVs will decide to provide *only* 32-bit
>David> libraries, which could in turn force other ISVs to stay with
>David> 32-bit just because they couldn't get the pre-requisite 64-bit
>David> libraries.  My understanding is that IRIX suffered from this
>David> effect.
>
>Very good point, and even if we went down that road one could argue we
>should only go for IP32 with long's being 64 bit.
>

I see the drawback...  :-D  But maybe Linux provides enough open-source 
alternatives to existing ISV libraries to limit the number of ISV's 
impacted by this kind of forced limitation...?

BTW, do you know what is the choice on Linux/ppc64 vs. the previous 
Linux/ppc implementation on the same topic(data-model sizes)?

>Just say no ;)
>

FiX

-- 
Francois-Xavier "FiX" KOWALSKI     /_ __    Tel:+33 (0)4 76 14 63 27
Telecom Infrastructure Division   / //_/    Telnet: 779-6327
SigTech eXpert                      /       http://www.hp.com/go/opencall
                               i n v e n t



--------------030804080000060806090200
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<html>
<head>
</head>
<body>
Jes Sorensen wrote:<br>
<blockquote type="cite" cite="mid:15437.49013.455822.995150@trained-monkey.org">
  <blockquote type="cite">
    <blockquote type="cite">
      <blockquote type="cite">
        <blockquote type="cite">
          <blockquote type="cite">
            <pre wrap="">"David" == David Mosberger <a class="moz-txt-link-rfc2396E" href="mailto:davidm@hpl.hp.com">&lt;davidm@hpl.hp.com&gt;</a> writes:<br></pre>
            </blockquote>
            </blockquote>
            </blockquote>
            </blockquote>
            </blockquote>
            <pre wrap=""><!----><br>David&gt; I think one point that hasn't been made so far is that we<br>David&gt; actively discourage supporting an ILP32 data model for IA-64<br>David&gt; Linux to avoid splitting ia64 linux into two different worlds<br>David&gt; (32-bit and 64-bit world).  If we supported ILP32, it's very<br>David&gt; likely that some ISVs will decide to provide *only* 32-bit<br>David&gt; libraries, which could in turn force other ISVs to stay with<br>David&gt; 32-bit just because they couldn't get the pre-requisite 64-bit<br>David&gt; libraries.  My understanding is that IRIX suffered from this<br>David&gt; effect.<br><br>Very good point, and even if we went down that road one could argue we<br>should only go for IP32 with long's being 64 bit.</pre>
            </blockquote>
            <br>
I see the drawback...&nbsp;<span -moz-smiley="s5"><span> :-D </span></span>&nbsp;But
maybe Linux provides enough open-source alternatives to existing ISV libraries
to limit the number of ISV's impacted by this kind of forced limitation...?<br>
            <br>
BTW, do you know what is the choice on Linux/ppc64 vs. the previous Linux/ppc
implementation on the same topic(data-model sizes)?<br>
            <br>
            <blockquote type="cite" cite="mid:15437.49013.455822.995150@trained-monkey.org">
              <pre wrap="">Just say no ;)</pre>
              </blockquote>
              <br>
FiX<br>
              <pre class="moz-signature" cols="$mailwrapcol">-- 
Francois-Xavier "FiX" KOWALSKI     /_ __    Tel:+33 (0)4 76 14 63 27
Telecom Infrastructure Division   / //_/    Telnet: 779-6327
SigTech eXpert                      /       <a class="moz-txt-link-freetext" href="http://www.hp.com/go/opencall">http://www.hp.com/go/opencall</a>
                               i n v e n t</pre>
              <br>
              </body>
              </html>

--------------030804080000060806090200--


