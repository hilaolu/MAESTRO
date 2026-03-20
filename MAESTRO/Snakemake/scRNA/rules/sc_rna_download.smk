
import os


def _get_url_for_file(wildcards):
    """Look up the original URL for a downloaded filename."""
    for url in FILES[wildcards.sample]["R1"] + FILES[wildcards.sample]["R2"]:
        if os.path.basename(url) == wildcards.filename:
            return url
    raise ValueError("URL not found for %s/%s" % (wildcards.sample, wildcards.filename))


def _local_fastqs(sample, read_key):
    """Map remote URLs to local temp paths under Result/Fastq/{sample}/."""
    return ["Result/Fastq/%s/%s" % (sample, os.path.basename(url))
            for url in FILES[sample][read_key]]


rule download_fastq:
    """Download a single FASTQ file from a remote URL."""
    output:
        fastq = temp("Result/Fastq/{sample}/{filename}")
    params:
        url = lambda wildcards: _get_url_for_file(wildcards)
    log:
        "Result/Log/{sample}_{filename}_download.log"
    benchmark:
        "Result/Benchmark/{sample}/{sample}_{filename}_Download.benchmark"
    shell:
        'wget -O {output.fastq} "{params.url}" > {log} 2>&1'
