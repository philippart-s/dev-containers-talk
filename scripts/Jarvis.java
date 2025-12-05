///usr/bin/env jbang "$0" "$@" ; exit $?
//DEPS dev.langchain4j:langchain4j:1.5.0 
//DEPS dev.langchain4j:langchain4j-mistral-ai:1.5.0 
//DEPS ch.qos.logback:logback-classic:1.5.6

import dev.langchain4j.model.chat.response.ChatResponse;

import dev.langchain4j.memory.ChatMemory;
import dev.langchain4j.memory.chat.MessageWindowChatMemory;
import dev.langchain4j.model.mistralai.MistralAiStreamingChatModel;
import dev.langchain4j.service.AiServices;
import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.TokenStream;

import java.util.concurrent.CompletableFuture;


interface Assistant {
        @SystemMessage("Tu es JARVIS, un assistant virtuel expert dans le développement Java.")
        TokenStream chat(String message);
}
void main() {

    MistralAiStreamingChatModel streamingChatModel = MistralAiStreamingChatModel.builder()
            .apiKey(System.getenv("OVH_AI_ENDPOINTS_ACCESS_TOKEN"))
            .modelName(System.getenv("OVH_AI_ENDPOINTS_MODEL_NAME"))
            .baseUrl(
                    System.getenv("OVH_AI_ENDPOINTS_MODEL_URL"))
            .maxTokens(512)
            .build();

    ChatMemory chatMemory = MessageWindowChatMemory.withMaxMessages(10);

    Assistant assistant = AiServices.builder(Assistant.class)
            .streamingChatModel(streamingChatModel)
            .chatMemory(chatMemory)
            .build();

    System.out.println(
            "💬: Bonjour JARVIS. Explique en quelques lignes ce que sont les Dev Containers.\n");
    TokenStream tokenStream = assistant
            .chat("Bonjour JARVIS. Explique en quelques lignes ce que sont les Dev Containers.");
    CompletableFuture<ChatResponse> futureChatResponse = new CompletableFuture<>();
    System.out.print("🤖:");
    tokenStream
            .onCompleteResponse((ChatResponse response) -> futureChatResponse.complete(response))
            .onPartialResponse(System.out::print)
            .onError(Throwable::printStackTrace).start();
    futureChatResponse.join();
}