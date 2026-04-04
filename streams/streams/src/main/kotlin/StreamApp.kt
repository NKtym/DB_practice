import org.apache.kafka.common.serialization.Serdes
import org.apache.kafka.streams.*
import org.apache.kafka.streams.kstream.*
import java.time.Duration
import java.util.*

fun main() {

    val props = Properties().apply {
        put(StreamsConfig.APPLICATION_ID_CONFIG, "kotlin-streams-app")
        put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092")
        put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().javaClass)
        put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().javaClass)
    }

    val builder = StreamsBuilder()

    val stream: KStream<String, String> = builder.stream("simple")

    val transformed: KStream<String, String> = stream.mapValues { value ->
        val eventType = Regex("\"eventType\":\"(.*?)\"")
            .find(value)
            ?.groupValues?.get(1) ?: "UNKNOWN"

        eventType
    }

    val grouped: KGroupedStream<String, String> = transformed.groupByKey()

    val windowedCounts: KTable<Windowed<String>, Long> =
        grouped
            .windowedBy(TimeWindows.ofSizeWithNoGrace(Duration.ofMinutes(1)))
            .count()

    val output: KStream<String, String> = windowedCounts
        .toStream()
        .map { windowedKey, count ->
            val key = windowedKey.key()
            val windowStart = windowedKey.window().start()

        println("subscriptionId: $key, count: $count, windowStart: $windowStart")

            KeyValue(
                key,
                """{"subscriptionId":"$key","count":$count,"windowStart":$windowStart}"""
            )
        }

    output.to("streams")

    val streams = KafkaStreams(builder.build(), props)

    streams.start()

    Runtime.getRuntime().addShutdownHook(Thread(streams::close))
}