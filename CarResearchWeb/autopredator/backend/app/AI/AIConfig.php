<?php
declare(strict_types=1);

namespace App\AI;

return [
    'provider' => env('AI_PROVIDER', 'ollama'),
    'ollama' => [
        'base_url' => env('OLLAMA_BASE_URL', 'http://localhost:11434'),
        'model' => env('OLLAMA_MODEL', 'llama3.2:3b'),
        'timeout' => 120,
        'temperature' => 0.2
    ],
    
    'features' => [
        'enrichment' => true,
        'content_gen' => true,
        'autocomplete' => true,
        'max_tokens' => 2048
    ],
    
    'prompts' => [
        'car_enrichment' => "Extract structured specs from this car data. Output JSON with confidence scores. Data: {data}",
        'variant_recommend' => "Recommend similar variants for {model}. Consider price, fuel, features. JSON only.",
    ]
];

